<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24" >
            <a-form-model-item label="專案名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectId">
              <a-select v-model="model.projectId" @change="getAll" placeholder="請選擇專案"  :disabled=editable>
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="diskName">
              <a-input v-model="model.diskName" placeholder="請輸入名稱" :disabled="editable" ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="請輸入描述"  :disabled="editable"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="大小" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="size">
              <a-input v-model="model.size" placeholder="請輸入大小"  :disabled="justable"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="類型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="type">
              <a-select v-model="model.type"  placeholder="請選擇類型" :disabled="justable">
                <a-select-option v-for="type in types":value="type.value" >{{type.text}}</a-select-option>
              </a-select>

            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="來源" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="source">
              <j-dict-select-tag type="list" v-model="model.source" dictCode="disk_source" placeholder="請選擇來源" @change="getsource(model.source)" :disabled="justable"/>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showSource">
            <a-form-model-item label="來源id" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="sourceId">
              <a-select v-model="model.sourceId"  placeholder="請選擇" :disabled="justable">
                <a-select-option v-for="types in sourcetype":value="types.value" >{{types.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="合約日期啟" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
              <j-date v-model="model.startTime" placeholder="請選擇開始時間" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="合約日期止" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
              <j-date v-model="model.endTime" placeholder="請選擇終止時間" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="是否加密" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="bootable">
              <j-dict-select-tag type="list" v-model="model.bootable" dictCode="bootable" placeholder="請選擇是否加密" :disabled="justable"/>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showoption">
            <a-form-model-item label="審核意見" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="optionsText" >
              <a-textarea v-model="model.optionsText" placeholder="請輸入審核意見" ></a-textarea>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'
  export default {
    name: 'OsApplyDiskForm',
    components: {
    },
    props: {
      //表單禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false
      }
    },
    data () {
      return {
        model:{
         },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {
          diskName: [
            { required: true, message: '請輸入名稱!'},
          ],
          size: [
            { required: true, message: '請規定大小!'},
          ],
          type: [
            { required: true, message: '請選擇類型!'},
          ],
          startTime: [
            { required: true, message: '請輸入開始時間!'},
          ],
          endTime: [
            { required: true, message: '請輸入結束時間!'},
          ],
          projectId:[
            { required: true, message: '請選擇專案!'},
          ]

        },
        url: {
          add: "/os/osApplyDisk/add",
          edit: "/os/osApplyDisk/edit",
          queryById: "/os/osApplyDisk/queryById",
          getType: "/os/osApplyDisk/getType",
          agree: "/os/osOption/agree",
          refuse: "/os/osOption/refuse",
          getImg: "/os/osApplyDisk/getImg",
          getVolume: "/os/osApplyDisk/getVolume",
          getSnapshot: "/os/osApplyDisk/getSnapshot",
          getProject: "/os/osApply/getProject",
        },
        types:[],
        projects:[],
        sourcetype:[],
        editable: false,
        justable: false,
        showoption: false,
        showSource: false
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //備份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
     // this.getType(this.modelDefault);
      this.getProjects(this.modelDefault);
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
        this.showoption = this.model.showoption;
        if(this.model.id){
          this.getAll();
        }
        if(this.model.source=="1" || this.model.source=="2" || this.model.source=="3"){
          this.getsource(this.model.source);
        }
        if(this.model.options=="1" || (this.model.options=="2" && this.model.status!=null) ){
          this.editable=true
          this.justable=true
        }else if(this.model.options=="2" && this.model.status==null){
          this.editable=true
          this.justable=false
        }
      },
      submitForm () {
        const that = this;
        this.projects.forEach((r)=>{
          if(r.value==that.model.projectId){
            that.model.projectName = r.text;
          }
        })
        // 觸發表單驗證
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

        })
      },
      getAll(){
        this.getType();
      },
      getProjects(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getProject;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
          }
        })
      },
      //獲取捲來源
      getsource(source){
        const that = this;
        that.sourcetype = [];
        that.showSource=false;
        if(source=="1"){//映像檔
          that.showSource=true
          let method = "post";
          let httpurl = this.url.getImg;
          httpAction(httpurl,this.model,method).then((res)=>{
            if(res.success){
              const result = res.result
              result.forEach((r)=>{
                this.sourcetype.push({
                  value:r.imgId,
                  text:r.imgName
                })
              })
            }
          })

        }else if(source=="2"){//快照
          that.showSource=true
          let method = "post";
          let httpurl = this.url.getSnapshot;
          httpAction(httpurl,this.model,method).then((res)=>{
            if(res.success){
              const result = res.result
              result.forEach((r)=>{
                this.sourcetype.push({
                  value:r.snapshotId,
                  text:r.snapshotName
                })
              })
            }
          })
        }else if(source=="3"){//卷
          that.showSource=true
          let method = "post";
          let httpurl = this.url.getVolume;
          httpAction(httpurl,this.model,method).then((res)=>{
            if(res.success){
              const result = res.result
              result.forEach((r)=>{
                this.sourcetype.push({
                  value:r.volumeId,
                  text:r.volumeName
                })
              })
            }
          })
        }
      },
      //同意
      agree(){
        const that = this;
        let method = "post";
        this.model.applyType = "3";
        this.model.optionsType="1";
        let httpurl = this.url.agree;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
      //拒絕
      refuse(){
        const that = this;
        this.model.applyType = "3";
        this.model.optionsType="0";
        let method = "post";
        let httpurl = this.url.refuse;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
            that.loadData();
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
      getType(){
        let record = this.model;
        this.types=[];
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getType;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.types.push({
                value:r.type,
                text:r.type
              })
            })
          }
        })
      }
    }
  }
</script>