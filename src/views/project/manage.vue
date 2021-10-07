<template>
  <a-card :bordered="false">
    <!-- 查询区域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="實例名稱">
              <a-input placeholder="请输入實例名稱" v-model="queryParam.instanceName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="鏡像名稱">
              <a-input placeholder="请输入鏡像名稱" v-model="queryParam.imgName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查询</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展开' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查询区域-END -->

    <!-- 操作按钮区域 -->
    <div class="table-operator">
<!--      <a-button @click="handleApply" type="primary" icon="plus">申請</a-button>-->
<!--      <a-button type="primary"  @click="handlePowerOn" >開機</a-button>-->
<!--      <a-button type="primary"  @click="handleShutDown" >關機</a-button>-->
<!--      <a-button type="primary"  @click="handleReboot" >重啓</a-button>-->
<!--      <a-button type="primary"  @click="handleShowConsole" >控制臺</a-button>-->


<!--      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>-->
<!--      <a-button type="primary" icon="download" @click="handleExportXls('申請明細檔')">导出</a-button>-->
<!--      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">-->
<!--        <a-button type="primary" icon="import">导入</a-button>-->
<!--      </a-upload>-->
      <!-- 高级查询区域 -->
<!--      <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>-->
      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>删除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table区域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已选择 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>项
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
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无图片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下载
          </a-button>
        </template>

        <span slot="instanceName" slot-scope="text, record">
          <a @click="handleRouter(record)">{{ text }}</a>
        </span>

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">编辑</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
<!--              <a-menu-item>-->
<!--                <a @click="handleAdjustResource(record)">調整資源</a>-->
<!--              </a-menu-item>-->
<!--              <a-menu-item>-->
<!--                <a @click="handleAddUserProject(record)">指定管理员</a>-->
<!--              </a-menu-item>-->
              <a-menu-item>
               <new-j-select-multi-user v-model="formData.multiUser" selectButtonText="添加用户" :query-config="selectUserQueryConfig"/>
              </a-menu-item>
            </a-menu>
<!--            <a-menu slot="overlay">-->
<!--              <a-menu-item>-->
<!--                <a @click="handleDetail(record)">详情</a>-->
<!--              </a-menu-item>-->
<!--              <a-menu-item>-->
<!--                <a-popconfirm title="确定删除吗?" @confirm="() => handleDelete(record.id)">-->
<!--                  <a>删除</a>-->
<!--                </a-popconfirm>-->
<!--              </a-menu-item>-->
<!--            </a-menu>-->

          </a-dropdown>
        </span>

      </a-table>
    </div>

    <os-instance-modal ref="modalForm" @ok="modalFormOk"></os-instance-modal>
    <Select-User-Project-Modal ref="selectUserProjectModal" @selectFinished="selectOK"></Select-User-Project-Modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import OsInstanceModal from './modules/OsInstanceModal'
  import { deleteAction, getAction,downFile,getFileAccessHttpUrl } from '@/api/manage'
  import SelectUserProjectModal from './modules/SelectUserProjectModal'
  import NewJSelectMultiUser from '@/components/jeecgbiz/NewJSelectMultiUser'

  export default {
    name: 'manage',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      OsInstanceModal,
      SelectUserProjectModal,
      NewJSelectMultiUser
    },
    data () {
      return {
        description: '申請明細檔管理页面',
        // 表头
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
            title:'實例名稱',
            align:"center",
            dataIndex: 'instanceName',
            scopedSlots: { customRender: 'instanceName' }
          },
          {
            title:'狀態',
            align:"center",
            dataIndex: 'status'
          },
          {
            title:'鏡像名稱',
            align:"center",
            dataIndex: 'imgName'
          },
          {
            title:'實例類型',
            align:"center",
            dataIndex: 'flavorName'
          },
          {
            title:'實例配置',
            align:"center",
            dataIndex: 'configureInfo'
          },
          {
            title:'IP地址',
            align:"center",
            dataIndex: 'ipAddress'
          },
          {
            title:'所屬項目',
            align:"center",
            dataIndex: 'projectName'
          },
          {
            title:'運行時長',
            align:"center",
            dataIndex: 'runTime'
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
          list: "/openstack/osInstance/list",
          delete: "/openstack/osInstance/delete",
          deleteBatch: "/openstack/osInstance/deleteBatch",
          exportXlsUrl: "/openstack/osInstance/exportXls",
          importExcelUrl: "openstack/osInstance/importExcel",
          powerOnUrl: "/openstack/osInstance/powerOn",
          shutDownUrl: "/openstack/osInstance/shutDown",
          rebootByHARDUrl: "/openstack/osInstance/rebootByHARD",
          rebootBySOFTUrl: "/openstack/osInstance/rebootBySOFT",
          createSnapshotUrl: "/openstack/osInstance/createSnapshot"

        },
        dictOptions:{},
        superFieldList:[],
        formData: {
          areaLinkage1: '110105',
          areaLinkage2: '140221',
          sex: 1,
          orgCodes: 'A02A01,A02A02',
          departId: '57197590443c44f083d42ae24ef26a2c,a7d7e77e06c84325a40932163adcdaa6',
          userIds: 'admin',
          multiUser: 'admin,jeecg',
          jCheckbox: 'spring,jeecgboot',
          jCodeEditor: `function sayHi(word) {\n  alert(word)\n}\nsayHi('hello, world!')`,
          jDate: '2019-5-10 15:33:06',
          jEditor: '<h2 style="text-align: center;">富文本编辑器</h2> <p>这里是富文本编辑器。</p>',
          jEllipsis: '这是一串很长很长的文字段落。这是一串很长很长的文字段落。这是一串很长很长的文字段落。这是一串很长很长的文字段落。',
          jSlider: false,
          jSelectMultiple: 'Integer,Boolean',
          imgList:[],
          fileList:[],
          content: '',
          cronExpression: '* * * * * ? *',
        },
        // 选择用户查询条件配置
        selectUserQueryConfig: [
          {key: 'phone', label: '电话'},
        ],
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
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'instanceName',text:'實例名稱',dictCode:''})
        fieldList.push({type:'string',value:'options',text:'申請狀態',dictCode:''})
        fieldList.push({type:'string',value:'status',text:'狀態',dictCode:''})
        fieldList.push({type:'string',value:'represent',text:'描述',dictCode:''})
        fieldList.push({type:'string',value:'imgId',text:'鏡像id',dictCode:''})
        fieldList.push({type:'string',value:'isDelete',text:'刪除實例時是否刪除卷',dictCode:''})
        fieldList.push({type:'string',value:'flavorId',text:'實例類型id',dictCode:''})
        fieldList.push({type:'string',value:'runStatus',text:'運行狀態',dictCode:''})
        fieldList.push({type:'string',value:'securityName',text:'安全組',dictCode:''})
        fieldList.push({type:'string',value:'networkId',text:'網絡',dictCode:''})
        this.superFieldList = fieldList
      },
      handleApply(){
        this.$router.push({name: 'os-OsApplyList',params:{}})
      },
      handlePowerOn(){
        if (this.selectionRows.length != 1){
          this.$message.error("請選擇一條記錄！")
          return
        }

        let that = this;
        this.$confirm({
          title: '确定開啓'+this.selectionRows[0].instanceName+'吗?',
          //content: 'When clicked the OK button, this dialog will be closed after 1 second',
          onOk() {
            that.powerOn();
          },
          onCancel() {},
        });

      },
      powerOn(){
        let that = this;
        this.loading = true;
        getAction(that.url.powerOnUrl, this.selectionRows[0]).then((res) => {
          if (res.success) {
            that.$message.success(res.message);
            that.loadData();
            that.selectionRows = [];
            that.selectedRowKeys = [];
          } else {
            that.$message.warning(res.message);
          }
          this.loading = false;
        });
      },

      handleShutDown(){
        if (this.selectionRows.length != 1){
          this.$message.error("請選擇一條記錄！")
          return
        }

        let that = this;
        this.$confirm({
          title: '确定關閉'+this.selectionRows[0].instanceName+'吗?',
          //content: 'When clicked the OK button, this dialog will be closed after 1 second',
          onOk() {
            that.shutDown();
          },
          onCancel() {},
        });
      },
      shutDown(){
        let that = this;
        this.loading = true;
        getAction(that.url.shutDownUrl, this.selectionRows[0]).then((res) => {
          if (res.success) {
            that.$message.success(res.message);
            that.loadData();
            that.selectionRows = [];
            that.selectedRowKeys = [];
          } else {
            that.$message.warning(res.message);
          }
          this.loading = false;
        });
      },

      handleReboot(){
        if (this.selectionRows.length != 1){
          this.$message.error("請選擇一條記錄！")
          return
        }

        let that = this;
        this.$confirm({
          title: '确定重啓'+this.selectionRows[0].instanceName+'吗?',
          //content: 'When clicked the OK button, this dialog will be closed after 1 second',
          onOk() {
            that.reboot(that.selectionRows[0],that.url.rebootByHARDUrl);
          },
          onCancel() {},
        });
      },
      reboot(record,url){
        let that = this;
        this.loading = true;
        getAction(url, record).then((res) => {
          if (res.success) {
            that.$message.success(res.message);
            that.loadData();
            that.selectionRows = [];
            that.selectedRowKeys = [];
          } else {
            that.$message.warning(res.message);
          }
          this.loading = false;
        });
      },
      handleAddUserProject() {
        if (false ) {
          this.$message.error("请选择一个部门!")
        } else {
          debugger
          this.$refs.selectUserProjectModal.visible = true;
        }
      },
      selectOK(data) {
        alert('ok')
        // let params = {};
        // params.depId = this.currentDeptId;
        // params.userIdList = [];
        // for (var a = 0; a < data.length; a++) {
        //   params.userIdList.push(data[a]);
        // }
        // console.log(params);
        // postAction(this.url.edit, params).then((res) => {
        //   if (res.success) {
        //     this.$message.success(res.message);
        //     this.loadData();
        //   } else {
        //     this.$message.warning(res.message);
        //   }
        // })
      },

    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>