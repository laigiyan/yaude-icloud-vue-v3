<template>
  <a-card :bordered="false">
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="類型">
              <j-dict-select-tag type="list" v-model="queryParam.applyType" dictCode="apply_type" placeholder="請選擇類型"/>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展開' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->

    <!-- 操作按鈕區域 -->
    <div class="table-operator">
     <!-- <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>
      <a-button type="primary" icon="download" @click="handleExportXls('審核意見細檔')">導出</a-button>
      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">
        <a-button type="primary" icon="import">導入</a-button>
      </a-upload>-->
      <a-button @click="handleOption()" type="primary" icon="plus">審核</a-button>
      <!-- 高級查詢區域 -->
     <!-- <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>-->
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>刪除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table區域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已選擇 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>項
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無圖片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下載
          </a-button>
        </template>

        <span slot="action" slot-scope="text, record">
          <a @click="handleOption1(record)">審核</a>
        </span>

      </a-table>
    </div>

    <os-option-modal ref="modalForm" @ok="modalFormOk()" ></os-option-modal>
    <os-apply-modal ref="applymodalForm" @agree="(projectId)=>modalFormAgree(projectId)" @refuse="modalFormRefuse()"></os-apply-modal>
    <os-apply-floatip-modal ref="floatipmodalForm"@agree="(projectId)=>modalFormAgree(projectId)" @refuse="modalFormRefuse()"></os-apply-floatip-modal>
    <os-apply-disk-modal ref="diskmodalForm" @agree="(projectId)=>modalFormAgree(projectId)" @refuse="modalFormRefuse()"></os-apply-disk-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import { httpAction, getAction } from '@/api/manage'
  import OsOptionModal from './modules/OsOptionModal'
  import OsApplyModal from './modules/OsApplyModal'
  import OsApplyFloatipModal from './modules/OsApplyFloatipModal'
  import OsApplyDiskModal from './modules/OsApplyDiskModal'

  export default {
    name: 'OsOptionList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      OsOptionModal,
      OsApplyModal,
      OsApplyFloatipModal,
      OsApplyDiskModal
    },
    data () {
      return {
        description: '審核意見細檔管理頁面',
        // 表頭
        columns: [
          {
            title: '#',
            dataIndex: '',
            key:'rowIndex',
            width:60,
            align:"center",
            customRender:function (t,r,index) {
              return parseInt(index)+1;
            }
          },
          {
            title:'名稱',
            align:"center",
            dataIndex: 'applyName'
          },
          {
            title:'申請類型',
            align:"center",
            dataIndex: 'options_dictText'
          },
          {
            title:'狀態',
            align:"center",
            dataIndex: 'status_dictText'
          },
          {
            title:'審核類型',
            align:"center",
            dataIndex: 'applyType_dictText'
          },
          {
            title:'是否同意',
            align:"center",
            dataIndex: 'optionsType_dictText'
          },
          {
            title:'申請人',
            align:"center",
            dataIndex: 'applyBy'
          },
          {
            title: '操作',
            dataIndex: 'action',
            align:"center",
            fixed:"right",
            width:147,
            scopedSlots: { customRender: 'action' }
          }
        ],
        url: {
          list: "/os/osOption/list",
          delete: "/os/osOption/delete",
          deleteBatch: "/os/osOption/deleteBatch",
          exportXlsUrl: "/os/osOption/exportXls",
          importExcelUrl: "os/osOption/importExcel",
          applys: "os/osApply/applys",
          floatipapplys: "os/osApplyFloatip/floatipapplys",
          diskapplys: "os/osApplyDisk/diskapplys",
          getStatus: "/os/osOption/getStatus",
        },
        dictOptions:{},
        superFieldList:[],
        optionType:"",
      }
    },
    created() {
      this.getSuperFieldList();
    },
    computed: {
      importExcelUrl: function(){
        return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
      },
    },
    methods: {
      initDictConfig(){
      },
      modalFormAgree(projectId){
        let that = this;
        let httpurl = this.url.getStatus;
        let method = "post";
          let formData = {
            applyType: this.model.applyType,
            applyId: this.model.applyId,
            id: this.model.optionId,
            options: this.model.options,
            projectId: projectId
          }
          httpAction(httpurl,formData,method).then((res)=>{
            if(res.success){
              this.loadData();
            }else{
              that.$message.warning(res.message);
            }
          })
        },
      modalFormRefuse(){
        setTimeout(() => {
          this.loadData();
        }, 1000)
      },
      handleOption(){
        if (this.selectedRowKeys.length <= 0) {
          this.$message.warning('請選擇一條記錄！');
          return false;
        }else{
          var params = this.selectionRows[0] ;
          this.handleOption1(params);
        }
      },
      handleOption1:function(record){
        this.model = Object.assign({}, record);
        const result = "";
        this.model.optionId = this.model.id;
        this.model.id = this.model.applyId;
        this.model.showoption="true";
        let that = this;
        if(this.model.applyType==1){//vm
          let httpurl = this.url.applys;
          getAction(httpurl,this.model).then(res=>{
            if(res.success && res.result){
              that.result = res.result[0];
              that.result.showoption = "true";
              this.result.optionId = that.model.optionId;
              that.$refs.applymodalForm.edit(this.result);
              that.$refs.applymodalForm.title="審核";
            }
          })
        }else if(this.model.applyType==2){//ip
          let httpurl = this.url.floatipapplys;
          getAction(httpurl,this.model).then(res=>{
            if(res.success && res.result){
              that.result = res.result[0];
              that.result.showoption = "true";
              this.result.optionId = that.model.optionId;
              that.$refs.floatipmodalForm.edit(this.result);
              that.$refs.floatipmodalForm.title="審核";
            }
          })
        }else if(this.model.applyType==3){//磁盘
          let httpurl = this.url.diskapplys;
          getAction(httpurl,this.model).then(res=>{
            if(res.success && res.result){
              that.result = res.result[0];
              that.result.showoption = "true";
              this.result.optionId = that.model.optionId;
              that.$refs.diskmodalForm.edit(this.result);
              that.$refs.diskmodalForm.title="審核";
            }
          })
        }
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'applyId',text:'申請表id',dictCode:''})
        fieldList.push({type:'string',value:'optionsText',text:'審核意見',dictCode:''})
        fieldList.push({type:'string',value:'optionsType',text:'是否同意',dictCode:''})
        this.superFieldList = fieldList
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>