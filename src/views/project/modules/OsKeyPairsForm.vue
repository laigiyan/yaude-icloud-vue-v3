<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <!--<a-col :span="24">
            <a-form-model-item label="用戶名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="userId">
              <a-select v-model="model.userId" @change="getAll" placeholder="請選擇用戶" >
                <a-select-option v-for="user in users":value="user.value"  >{{user.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>-->
          <a-col :span="24" >
            <a-form-model-item label="項目名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectId">
              <a-select v-model="model.projectId"  @change="getAll" placeholder="請選擇項目" >
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="秘鑰名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="keyName">
              <a-input v-model="model.keyName" placeholder="請輸入秘鑰名稱"  :disabled="editKey"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showKey">
            <a-form-model-item label="指紋" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="fingerprint">
              <a-textarea v-model="model.fingerprint" placeholder="請輸入指紋" :disabled="editKey"></a-textarea>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showKey">
            <a-form-model-item label="公鑰" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="publicKey">
              <a-textarea v-model="model.publicKey" placeholder="請輸入公鑰" :disabled="editKey"></a-textarea>
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
    name: 'OsKeyPairsForm',
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
        },
        users:[],
        projects:[],
        showKey:false,
        editKey:false,
        url: {
          add: "/openstack/osKeyPairs/add",
          edit: "/openstack/osKeyPairs/edit",
          queryById: "/openstack/osKeyPairs/queryById",
          getProject: "/openstack/osKeyPairs/getProject",
        }
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
    this.getProjects();
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
        if(this.model.id){
          this.showKey=true;
          this.editKey=true;
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
    /*  getAll(){
        this.getProjects();
      },
      getUser(){
        let method = "post";
        let httpurl = this.url.getUser;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            debugger
            result.forEach((r)=>{
              this.users.push({
                value:r.userId,
                text:r.userName,
              })
            })
          }
        })
      },*/
      getProjects(){
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

    }
  }
</script>